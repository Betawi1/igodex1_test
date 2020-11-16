import React, { Component } from 'react'
import { connect } from 'react-redux'
import { accountSelector } from '../store/selectors'

class Navbar extends Component {
  render() {
    return (
      <nav className="navbar navbar-expand-lg navbar-dark bg-primary">
        <a className="navbar-brand" href="#/">IGODEX</a>
        <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">


        <select id="list" style="padding: 10px;" onchange="getSelectValue();">
          <option value="0x289375C7B96bf6d5b6031066b8Ff09745f026662">IGO</option>
          <option value="0xbF7A7169562078c96f0eC1A8aFD6aE50f12e5A99">BAT</option>
          <option value="0xddea378A6dDC8AfeC82C36E9b0078826bf9e68B6">ZRX</option>
          <option value="0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa">DAI</option>
        </select>

        <script>
          function getSelectValue()
            {
           var selectedValue = document.getElementById("list").value;
           alert(selectedValue);
          }
          getSelectValue();
          </script>




        </button>
        <ul className="navbar-nav ml-auto">
          <li className="nav-item">
            <a
              className="nav-link small"
              href={`https://etherscan.io/address/${this.props.account}`}
              target="_blank"
              rel="noopener noreferrer"
            >
              {this.props.account}
            </a>
          </li>
        </ul>
      </nav>
    )
  }
}

function mapStateToProps(state) {
  return {
    account: accountSelector(state)
  }
}

export default connect(mapStateToProps)(Navbar)
